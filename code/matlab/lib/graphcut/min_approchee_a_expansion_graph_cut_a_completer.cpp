/* MIN_APPROCHEE_A_EXPANSION_GRAPH_CUT  algorithme des alpha-expansions
 *       calculées avec la construction de graphes de Kolmogorov (2004)
 *
 * Usage: Ir=min_approchee_a_expansion_graph_cut(I,labels,beta);
 
 */


#include "mex.h"
#include "math.h"

#include "graph.h"
#include "graph.cpp"
#include "maxflow.cpp"



// Terme d'attache aux données
double attache_aux_donnees(double noisy, double reg)
{
    // fonction à compléter...

    return ...;
}

// Terme de régularisation
double regularisation(double reg1, double reg2)
{
    // fonction à compléter...
  return ...;
}

// Message d'erreur
void error_msg(char * msg)
{
    mexWarnMsgTxt("Erreur!");
    mexWarnMsgTxt("Usage: Ir=min_approchee_a_expansion_graph_cut(I,labels,beta)");
    mexErrMsgTxt(msg);
}

// Calcul d'une alpha-expansion
bool alpha_expansion(double * Id, double * Ir, long W, long H, double alpha, double beta)
{
    bool change=false, non_sousmodulaire=false;
    long Npix=W*H;
    
    Graph* g;              // graphe
    Graph::node_id *nodes; // tableau des noeuds du graphe
       
     /* Allocation du graphe */    
    
     g = new Graph(Npix,2*Npix,&error_msg);
     if(g==NULL)
        error_msg("Memory allocation for the graph failed!");
    
     nodes=new Graph::node_id[Npix];
     if(nodes==NULL)
        error_msg("Memory allocation failed! (array of nodes could not be created)");
        
     // Création des noeuds
     for(long p=0; p<Npix; p++)
         nodes[p]=g->add_node(); 
     
     
  /* Construction du graphe */
        
    // Création des arcs
    for(long i=0; i<W; i++)
    {
        long offset=i*H;
        for(long j=0; j<H; j++)
        {
            long pix=offset+j; // coordonnée linéaire du pixel courant
            
            // Termes d'attache aux données
            double E0=attache_aux_donnees(Id[pix],Ir[pix]);    // vraisemblance si l'on garde la même valeur
            double E1=attache_aux_donnees(Id[pix],alpha);      // vraisemblance si l'on prend la valeur alpha
            
            if(E0<E1)
                g->add_tweights(nodes[pix],E1-E0,0); // arc source -> noeud i
            else
                g->add_tweights(nodes[pix],0,E0-E1); // arc noeud i -> puits
            
            // Termes de régularisation
            if(j<H-1)
            {
                double E00=beta*regularisation(Ir[pix],Ir[pix+1]);
                double E01=beta*regularisation(Ir[pix],alpha);
                double E10=beta*regularisation(alpha,Ir[pix+1]);
                double E11=beta*regularisation(alpha,alpha);
                
                if(E10>E00)
                    g->add_tweights(nodes[pix],E10-E00,0); // arc source -> noeud i
                else
                    g->add_tweights(nodes[pix],0,E00-E10); // arc noeud i -> puits

                if(E11>E10)
                    g->add_tweights(nodes[pix+1],E11-E10,0); // arc source -> noeud i
                else
                    g->add_tweights(nodes[pix+1],0,E10-E11); // arc noeud i -> puits
            
                if(E01+E10-E00-E11>=0)
                    g->add_edge(nodes[pix],nodes[pix+1],E01+E10-E00-E11,0);
                else
                    non_sousmodulaire=true;
                    
            }
                
            if(i<W-1)
            {
                double E00=beta*regularisation(Ir[pix],Ir[pix+W]);
                double E01=beta*regularisation(Ir[pix],alpha);
                double E10=beta*regularisation(alpha,Ir[pix+W]);
                double E11=beta*regularisation(alpha,alpha);
                
                if(E10>E00)
                    g->add_tweights(nodes[pix],E10-E00,0); // arc source -> noeud i
                else
                    g->add_tweights(nodes[pix],0,E00-E10); // arc noeud i -> puits

                if(E11>E10)
                    g->add_tweights(nodes[pix+W],E11-E10,0); // arc source -> noeud i
                else
                    g->add_tweights(nodes[pix+W],0,E10-E11); // arc noeud i -> puits
            
                if(E01+E10-E00-E11>=0)
                    g->add_edge(nodes[pix],nodes[pix+W],E01+E10-E00-E11,0);
                else
                    non_sousmodulaire=true;
            }
        }
    }
    
    if(non_sousmodulaire)
        mexWarnMsgTxt("Energie non sous-modulaire, troncature réalisée");
        
  /* Calcul de la coupe minimale */
    double cout=g->maxflow();
    
    
    
  /* Déduction de l'image régularisée */
    long Npixchanged=0;
    for(long pix=0; pix<Npix; pix++)
    {
        // si le noeud n'est plus relié à la source, c'est qu'il faut associer
        // la valeur alpha au pixel correspondant dans l'image régularisée
        if(g->what_segment(nodes[pix])!=(Graph::SOURCE))
        {
            Ir[pix]=alpha;
            //mexPrintf("*");
            Npixchanged++;
            change=true;
        }
    }
    if(change)
        mexPrintf("*%d*",Npixchanged);
    
    /* Liberation de la mémoire (destruction du graphe de l'itération courante)*/
    delete g;
    delete [] nodes;
    
    return change;
}

// Algorithme des alpha-expansions
void minimize_energy(double * Id, double * Ir, long W, long H, double * label, long Nlabels, double beta)
{
    bool change=false;
    long iter=1;
    long MAXITER=5;
    
    // initialisation au maximum de vraisemblance
    for(long pix=0; pix<W*H; pix++)
    {
        double Emin=1E20;
        for(long i=0; i<Nlabels; i++)
        {
            double E=attache_aux_donnees(Id[pix],label[i]);
            if(E<Emin)
            {
                Emin=E;
                Ir[pix]=label[i];
            }
        }
    }
    
    
 // tant qu'il y a des changements, réaliser des alpha-expansions pour tous les labels alpha
    for(iter=1; iter<=MAXITER; iter++)
    {
        change=false;
        mexPrintf("Iteration %d:\n",iter);
        for(long index_alpha=0; index_alpha<Nlabels; index_alpha++)
        {
            // affichage
            if(((index_alpha+1)%10)==0)
                mexPrintf("\n");
            mexPrintf("%.1f",label[index_alpha]);
            mexPrintf("(%d)--",index_alpha+1);
            
            // calcul de l'expansion sur le niveau label[index_alpha]
            bool has_changed=alpha_expansion(Id,Ir,W,H,label[index_alpha],beta);
            change=change||has_changed;
        }
        if(!change)
            break;
        mexPrintf("\n\n");
    }
}





// Fonction principale (gère la liaison avec Matlab)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
const mxArray *prhs[])
{
  /* Vérification du nombre d'arguments */
    if ( nrhs != 3 ) {
        error_msg("Nombre d'arguments d'entrée incorrect!");
    } else if ((nlhs != 1)) {
        error_msg("Nombre d'arguments de sortie incorrect!");
    }
    
  /* Vérification du type des arguments */
    if (!mxIsDouble(prhs[0])||mxIsComplex(prhs[0])||
    !mxIsDouble(prhs[1])||mxIsComplex(prhs[1])||((mxGetM(prhs[1])!=1)&&(mxGetN(prhs[1])!=1))||
    !mxIsDouble(prhs[2])||mxIsComplex(prhs[2])||mxGetM(prhs[2])!=1||mxGetN(prhs[2])!=1
    ) {
        error_msg("Mauvais type d'argument!");
    }
    
    long W,H,Nlabels;
    W = mxGetM(prhs[0]);
    H = mxGetN(prhs[0]);
    Nlabels = mxGetM(prhs[1])*mxGetN(prhs[1]);
    
  /* On récupère les paramètres scalaires */
    double beta;
    beta=*mxGetPr(prhs[2]);
    
  /* On crée l'image de sortie */
    plhs[0] = mxCreateDoubleMatrix(W,H, mxREAL);
    
  /* On récupère les adresses des matrices d'entrée et de sortie */
    double *Id, *Ir, *label;
    
    Id = mxGetPr(prhs[0]);
    label = mxGetPr(prhs[1]);
    Ir = mxGetPr(plhs[0]);
    
    minimize_energy(Id,Ir,W,H,label,Nlabels,beta);
}

